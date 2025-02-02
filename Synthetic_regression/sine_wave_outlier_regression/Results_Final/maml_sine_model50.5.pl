��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1552333367744qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1552333370720qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1552333368320qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1552333369184q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1552333367936q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1552333369280q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1552333367744qX   1552333367936qX   1552333368320qX   1552333369184qX   1552333369280qX   1552333370720qe.(       �a�+l:��	?l?&2N�_�P�{�?��ν�c�>�GV�"�<@F�<f}���?Ɲ ?h/->#�L���P>���<�I��f��>��t���ʾ��6�v}�}޷=��?6s����>�O7�a�y����=, :������'�>�j�>q>���3�=
�?׊'�(       �Ǽ=C��5č�x6>dW�>�<P?��f>���Ԥ�>�1��,*�?��?����D�i�����Z�?S�Z��?4���Z�ձ6>
r�>xl���|?��n=��J���>���=�l6=��C��I�=p5�?>�H��o
��SL=菠<&�N>�^���?��>@      j�}=���l�J�D����ʥ�=bX�$�8�dF�,�g�46���ƴ=��=�������ԁ�=���=�м���a=؍�)"9�s��C���ڽ�)
��2��`�=��cS(<�_/�=��o�"�;�}�<V�;�Ӡ�@��=i(�l/3����k�~��ѐ�?�ھI���ۗ>������;�-����;]�%?6��=��۾�8��LN��*ᦽp3޿+�[=Ʋ߽t����E���G��V�����ʿ;ʨ�����c�d5�>�Ҏ�<�f��e�>���G#���>�݈���Խ��>D���0R��
`��>=-PS�@(��Q�� j�7�N�[w>9�Z�^%Ž���d�=���<��;Un.�)y>@m\;|dh�ܹ̽`.��v�������Z��ƒ�=� � s���E��Ɗ���
��J�<�*7��u�\���뉾���)P���;���:i<|sU���>,	?�F��⊿�c�3>Ø3���ɼ�-������d�&�8c�>�� >�=�����t�$���)�=w=�)��ՙ�SC�ޣ��M��=�ۗ=YO �Ε�<Ɠ=�`�>���>w��>���5��>������=�S?��ž�>�v>��%��ό=n�?�Ikh���N>�W�=.r�=�ϸ>p,�=�e�<;m�=?�	��Z?|�F='�;=�7=�PW>���<+�+��=�n�<q��>)s�>pc:=��߾흈��nþ�ա��
�>�u���ؽ֋�����(G���ڮ=�:�:T���J>��`�7rL<�\k>�ng��^���O��Y'>e>��>���>=��>��I�{>�Lz��s����;?��>`j=b7���F������R������2G?�eT=Ks�����e�>�td?V��K{���F��6Y�>�X&>�Ҟ����>�֓>��;���M>�!���ҽ{�C=5��=C��>5I=on۽�!m��FM><0$��!�E��=
��x�=��U>��?�}U =C�k�[o��(ܽ��#>�e=R�f>3C��~������<B���3�%>�0��Q/�j��=Y*	?u�>uiH>��o�>C�4>��m����>d��U?OH�<�/y=�9=�7#?�����$��O���`;�-2� �#��Y">�����s߾�:����ν�>>�����t��ݽ9��?iYR�#7A�]~���f׽@���>�L���>*�.���#>6��=[?��?�s�=�ֈ>��۽� �<���>��� S2>���>9e�=H���TE?rkž-��I�¿�bD�[˘���*��娽������>n]x�0��o�=�ο� ���>�I�?�J�Ŀ��B����?��ґ��Ή>ݻ��E�����?=���G?0@q�>?� U>���?���Ar��
@0�;�ԕ>�l�?զ"��,Ѿ�3;�5����� ��!�=7,K=�ֽ���=-�y�=�ҽ`��;��|��DԽ���0xq=�ㅼ��=0�/�������b�������:��QH=�4�q���]-���C�=� �����c�P����)������vl�t���������-��&;½�;��(�M2y�i͑>4�@�VC���F0�ಪ�����>���g��
�������ܼ�횾P&7�Lm,>�R�?�迁@
����'�uc1?���?��?�[W������%���r,�OC>��5��	4��ꚽ�(�s@=N�쾌B��
u3�Jg�����[�����q�a�Q��X>`YM�g�	�䞼�v�'��˿��!�:�ɿ�|�R� $�;�2��4��J�����>x�g�C#)>�房���`oپ
eJ=5<�����g��Ⱦ���5,��N����־~����w�
�1<
��<�W%�1���/ET=�S�${�Ȑ�����9V�˾�I��q�=!%����́i�)�>�<7�P��<�>�y>�1�>��B�������>�X�=%.��zT��ն���?�Ѽ���>1�F>fd����=j,��Y��K��f� ����ۏ���>��1���S>�䑾j�=zv�����n��+�ǽo�ox�pL�<ܖ�� �:�W��\C<�R>��������N 6� ���N�=T�=�Eս 58�H��>��#��$�D=�<��Z��=V2�=��@g��ٽ@b�=���=����,�=�u����&;O>�����J�u��hY�&���i[=�J������� �|׈�o�:�D��Pvx=�J����Ґ=k-!��=��I[�;���>B �=�Ot�UP��
	���1h?��ﾾE�l;>���+��:�D�o���ڱV=_D�=L� �Km7���|ߦ��đ�!��ҿ���ݲS�:��:��M�t?.�����B���J�y
>��5<�:�V�)�ܳ�:��=7Md��;z�Di�=��?�B��:�?�9�"���ȃG� G?������qs���]�&�g��.˼�e�i^ �e$��Za�"֭��N���7��^���8Q>�z���3�M���C�=ķ��v�Ⱦ�&������b>��2��� �	�^>Hԩ�C|"��F��Q<��8��o�Y<<�A���#�����^�D��>����@a>�+�<G�<�Ep��������_�t�I�žr�>� ���=a�=�4ʼ?���f?�� ����ž@�$��Y*���>�J�?�����Ͼ����!>���=�)��ob��N��x��<f��:ޜ�ZG$�y{?N����(7?����q�=b�}�Ha�?�{��5���2����Z~��`�jz>���(��������{v�L�*��{�>b�l���F>�aA�mp�ų�;gj���=3f=�f$���C��N���b���U�`R����*�������<-�(U�y�Ӽ%/齯l5�ySE��f<!F��N��x��<����A#��\�=K�ڽ�gE<S����6�=�xý����������Y#H��� ��V���tj=��w��CZ=��<��K=�y��Oz�4�<��i��Bl��ؓ��I�S�}=5[ֽcY=�~���W=�wҼ7%�= 
���p������������L�rAA�/�_?�ٯ�>��U�1=⸽�·=}�>�T�V�:T�=�d6�����3>��Ƚͳ�4��n?�PJ=!; ���s�yʖ?"]�@2����z��ÿA�>"��{�����x�#���=��.��=�}[�=E ��$��^���m�;�'	}�0'Y��K�=lR#>�/����>��'��*_����>NC���i�>�0q����_}>��=A���� ��<�~=u��=���2��G����= Q����>�$?����8�R�$=��c>�nl�^��>:8�n2�=�q����=��=���
�`曾�����&>�KR=J�2�t�<�a7�;R�e�<,0�>h�滾�$P�{t<�w!���!�6$B>�Sھ9���󉰼�^�<R/,<�g����;TL�MG����'���0�?y��o쾁��=�������zؿ�䕾�7!��:d?�w��ֽ��*��G=�Ѵ�>�R�?0T�������`�< �L��Ⱦ>��>�zﾺf��H+=hK�<Ԏ�PMG=�	����h�e�N$�Q3�%g���;DC,>�{R�:1�5_F��Z��1�>lW����ӪX��\� GѼ~½j�B�Vل�y� ?΀J��bw�M޼����NN���I���1>��?�d�6X�����>��ʾE����?g@�FS�=A`A>�h�=����$=#we=�؜�-�C�D���ڈ)��膼��=�!W�]����#<���y=����J��0�`=1��:](���Z�;�G�2�����A�ti8=a����X�Ă3����������ϋd�p�<$�콧�\=j��RS���7�:YGe���W��<̬�=����D�9أ�g�2����s����ɑ���{�Ѥ��D����\=���=�/�Ϟ�� =;�r>���o��8�,C����%��� S��I��>�V��2:?WYw>݅����<��=`n� vv=h:���� >��*�{ ��p���|�,�5��>�l7?���p�����=0�C���KN=�3޽���w?d�=J�V�eB�0���p�o<�ݛ>~`=��ս96�'a���/`<?����-�Q�	ĝ>���9C�>qH?m �>2���*V?#�޽�]>k�:?`:���q�=��?�����C��_���_<���oV�Yb�=$;2�=�ѻ֎�;\;������ �ռL�F�ͽhF�U�Q=��= �3Ax;^@���oݽ�鷼���7 ;,  >�E�? ߽�t��%��GD��$-=�C=eH9� N�=v��4�_��Oa����=�K=�=fM߽��i�?t#����B����o=��;��`e�8�[�p����Ȼ@��D.[=�;R���� �R��=�<���B+���L��S��&=���=�^㽘���~�;9Ճ��΍<2�&��_���&�.�W�������;WU�)��<>�C=��h��W��3���B,8>�p��+g�`�G�5_Q;����$Ao�����վ@C�>���X�������f����o��Y���4>G��2\����>�C��l���i��z����?_���t�&��t�>��"����f�w;�]꿮��5e�����x���=�%�P���z[��j�o<vڂ>.��u����/>�y �Oӽ����.��hn$�AC!?P�Ͻɓ>>��\�(�߽l2X�o��=���Q���=�5�����>IT^=pQ����=���z��rK�>UG�>�.-�dC�>zVZ>E~?`3?�B�m�� @�>�]��n�?�.���@ֶ=�娿�ٔ��!�7>�7B�A��=�w���? �o�ſ�7fJ��`��N����ƽaG$��)���E�<�6��Jz���>����dG���8	?�]{?.�뿩-�=i�9�o���]�_��=].ƿ�|�h�[�{PſX~н�4ڽ�bǿ6>��׆���J��5����>-����a�<9���z�I��?ym�I>��?������� +)�������<+�5>�JϿK�ྱ☿S�f?���>��!�24'>c(>|������>�	�J��8�˽l=f=@�?�	)=5I�ۦr��)���n��}��� ȿW2�pF�$���8�E܂�s�����<��p��7�<uC�p�����=��
���m>�\=J�O����sR�����!?E����v)?SWB=sܽlPp?	�K>��7�d�����j���� "��e(�>붽�v��;I�'B���z�>=�e��ܸi�q=X�̼���5�LjR=8/�M
>��=v��<`�<��<�}=4 �̮;=3D�=|ݽ���ň^�p����M<�U��D�HT�<��&�$�ѽ��=��=x]�;���v�����N��<�MV=��=hr~=_V������hwC=8��<���#�����b���c~=��1=���=���=̵2�� Ľ�� >�[���+�!}^�&�/�W
>�^m�&c]��,���XrX�=�{�H��[�=[b������½+������<�N����P=�C����C�
9���=�Ya�a�q�T�b玽9 &�	���ڢ�6��E9<�Yd���>b�8< ��*����
ν3&��}����@���ƽ����n=�#=��Ӽ> ���2����=�0>~>�GE>l^¾�j���b�=�>�=����޽G��~~:�è=��R�8�?��S�CѾq�;�J>>R�\>��!>��R?��>n�/2>�t�kk�>p�B<�>�+>AR>���=��6�a>)�k��.�?�?�>KP?�GB=�-?%$��<����`=�]¾�v�����_����'���>�ql=t�E�6@U>�ս�A���N>���>m�%��E�>�=6>�n̾��վq�#���<J�,=D��>��?���<����A>& �>Q7>��X=)M�нB�e=�=�B�����ھ[���x��=���>�����S>�j6��%�=���t�޾;�� t.>�耾p8��N��|b>���XnɼJ=�g5>��>����l��/-��J��[c>	8?��!=�o�Y�&=�C>���>p�Y<_M����<R�=/�����<!�������#>~�tMx>T*�>���<cI=3���n�=~GȽ�묽�K[=U�=Í�r隼���=ꠦ>�m�(       Y蕽E�㡴�m�м�ؼ�o��s�+_>��>]X��W߽#�J=č�>���٘�>�38>�.?��l>�]��G-,?ra ?�~>n�O����>�钽b˖>S8<Nt�=[���3�>Ylc>�~=���?��"?~�<�n#g�=�,��d>��<���       �|Y�(       ��������Ҿ�`���z�;Q�>�ҿ��K����\?4$H=��!��y���qҿx1��h��b��a�R�Oh+���	?�����9>Pྼb��^-�>�L=튕�8��T�>�����=��w�m>��V<�Vi�fu>Q���=���kE>���h>