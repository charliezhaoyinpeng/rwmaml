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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2002965418688qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2002965415328qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2002965419648qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2002965417056q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2002965417824q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2002965419360q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2002965415328qX   2002965417056qX   2002965417824qX   2002965418688qX   2002965419360qX   2002965419648qe.(       ����m'���-�9��>�U@�E�=�zÿⲰ��o�؏����c�,��wd�=��Z?�� �+rV�d7��ؒ�?�>��e�]����q��Ϳ�ۿqr@��1?��Կz�7�� ��q=�.(�>:g��ܿ��?GLt?��2�üΞ;?��ο(       ���>C5U�
&�=Rl��=r�8@Q>�ė=�q$��(L���>�X���Ӆ>̹�;�{�=�"?�������=�����!��
.V�3��>���>�?�4b�ً��I$��r�>_ ���稿[پ�W�O�%>O4>����=%=?����y��;�>W/�<�?(       �)�e`�=��O?��C�nD�~w,�Y���Y�?�4�=����1�=�?jR�=�c�Fn�� U����?-J�KIG?�"�������y�(1P<����k��wfܾ��̾츮>���>h��>���;
����>��>q,ƾ3 �>���>�>�~m=�s_�(        �4��j�>i�;J����e��*:����!��"G�7����>[��>	�?3�<��B��� ?&m>�� �W� =��V��HX>��>�,�XC��P�?�@D¾�'��a�>�����Q��F?�)ɽ�t�=��?�>8@Q�h��Q1t�� #����       ��H�@      bd=�Sd���4��ٿ`��9�< c�;�<y�<�*�&���7�6�8=�J�"i���=;�i>�}]�¤�<��^�������"�N�R�������S��Iµ��\��[z�E�>��	����:���?�b=����:E��)C�ߧȽ1p>�?wq�>�?	����>���=�2��5�>���մ�>Q�o=�̳�g#��)��Q
о",�>+�'�⾰��>���P>������ӽ<zO�C y>�C*���¾Ryo>]��>>��=t�̽Hf���^�GmӾH���F%���b���>F� >��y;}6S>�IѿY�A�,��Hp}=�y�=e�ý{{�ǊB���/�ȼ!+پ�ܳ�u%�3!����>8VN��cV�?}$��|����&?8G��G���]���['=n��ƿ8}*� ���?��� ? =`�׿u��F�?��=����~(�W��V��=�2
>n�_?�\��_f�� =�Ok=���=A���M >���A���)�Y{R���F�)���!�=�A����׾�\F�=D`ȹFb;B��=���2s��C�G� �����Z�=լ�=?����i%�.��=]���m�PƵ��x=�����#���<���=��>��=y�/���?����->~>S">\ �>?q��Ɠ�<��=v>"��� d]�j��>��>����y�<Դ�>��ý\�r>o���1ҽFK��{�b>��<�q���B>���=�T��Z�罶I���B�2P�=s,��*<��޿�p=_��=���>�Y�=�{ȿq����t�<�,�d� =��/���]�<N��ܯ���Y<��"�N�<=��h�.?�?�����(:�
!��.㨾FP�^!�tp<^��r�a�$��<��R��r*��	�?`󛾴�޽��`���Ծ�
�"^��fU��:���MQ?ڟX<Iv�=�i2�����q=���=@��G��O��=���jME��=��f!����J���r������݀�� e�=���=��>�=)eS=:�Լ,s�<�������,=-DP��,��'YD��Ә�02 =�|�<o��>$,l��0�Ib>~@i�H1ֽ:>�h��g*=�$��C/=�z!���2���=�	R�`��<jB�=�M=#�=¡ýI3�=� �+�����=l��=�ͽq��-lx=�Ϧ<���<��=TR�=N��A�= ����q��3P=��ؽ`4��C��OR�'(������ҽJV���5��6�hY8=`��\�}=7=��=���<���P-�<0��= U���/Ľ��\<�彧3y�Ú��`��EϺ��e뮽8��� -�4,Ͻ29���什V�h���Q���Ѽ�B�7܂<I��@h
=ei"������>�6�WH����=Kl���������̩i=��о+"�������ƾ�4=U&�ɿ]^�蘽(v�U��=�e��}�?'݁�Q����[.����2wȽ����I���L�3�ȾE2l�I�)�\+��꺾#^�n5����'���%�����+A�=�bM���|>1�=A�!���2=T�����B���'������cܻ����|j��m>=���;@�C�G����;=� �=w�=k4��������X�|�V=��,�_
���U<��(=��=ox�=x�ݼ�̃=H�߽�0�=���C����V��-=�I=U]���?�"��� ��;0@���=>�i�=jp�$$	�����˾7ϕ<45���N� ��߽'���#���F�����?������NG3�-����>���>����};��m^�ڙz�����C�]=?tn��.E�m	K�T�'� �?����I	�#�}�P�i=�x=��[�]p�>�H�L���+�sJ��>���͂���=�E�<=��=��V<zM�=�D�=w���{<�N�����%��=0�ؼ'B�vՕ��ս��|z#=OJb����=���!=��|��3�=��	�E���c��2���e�=)$=A�Y������G����=A�M�b��y�=�`�&?<=d��=����hi���Tտ?���B4>���<���Yƽs�w��G�>� �=^�3��n+>�\c��)���o�I��=��= �=嫍�.���tV1>I��>T���t�Wk<�(�[�>�m�=�O�<,Ub����>Hć;�^�* �=�ؿVD%=�b`=T��t��� ��{��{�ƽ��ҽ����E��G�<d����L��N6�'q��a�۾\p�=,(�f�>�>��E�&���(���ʾ�}�K >�O��(3"��>2�������->?M�<p�a�ė-? �W���c��ý=ӆ�
�G�Oځ�Y�n=&����������<P�����<��>�o�����;i���(=�a >��ݽ��=�l	���>2T���oE�*��=��=�8����C����X;#�,�r���1�=\�3�X����T��%�w��=v��h꺼�p��h��=���$'y=����0 �=����0������q��Y�c>3*F�YԼ�c�������0�ܴj��G���+��@=3����(=�/�>�����a��a<�)������"�����R�k/��>���+�d���,�n?������D� ��Q���=n`M��=�?HD�=�Sɽ�!��]eؽ�B�����8H��c�?�*>Ek�����}s��]��t�,?�w^��5�]�N�� ���
���>@��{Qu��Ĉ>�p�%5�c�>�e,=�ܾ'�Ǽ���3c�>���8�t?�.=�=���N���1'<��Ƚ<&��?ֲ?���W��>xϽă,>��<i�ɾ�s-��Az��\7�E<>�3�>$��>Y�a>5!�>9�;>	��=�~��|+=NB����=91>�>��6E��Տ�>:[�< t��� ?q>�> E��5�m>�9�H,-=���>W?���=�?����)y��/���e����='+�� !��� ��v{=.�<�����J?�2��=Q��	��+����$�S���>�fa��X>���J��= .�=���<p8<p���!�=�B�y��� �PE8=t�z<c������� �=�}<&�3�19H�dOM=�ͽ���=��>\,~=9�2�堇=�S��;,�=�R=�a���t�=���ž�ʎ�����Ž��D=����x�>4ֽ�ק���v#��-��r�U=�f���ȿ5	�Ƒ�=eS��I�;�F?1�h=�㉾\��>��V���z���r\>g�����=bW��*l�V>��I>j�<������2{>�	ھI	=P�|������7����I�}���,<m��=�>K7>�$�{(��r����������]v�l��`������=`j���=���>��*>2@����>�s����=�ڶ>ܒ��������<Mٚ�٘��	�t�t�>nj��Ǹҽ\L�:���ݾ[�D�m�3=+���d��c_ݾ�Z^����#/ɽe�=(�	>gi���n���������I�Yfl�+ꔿ�(��G�=������=h(?���ѳ��>����Kh��A�>M�k���N���,/=�'�=��>�G>��>��V=�x�<��&�O��V��=ł��F?�栽>�=�cԽj���J��=`��=lUɽ�����2>A�b���Mm����&�߽ێ�=������=G����J;�V ��\�=������P��A �}%�b��=n��;p�ٽ7�5��-�L�8A�\Ob=d:����H� 5��8&�<	4��վT��L���J����K�>��R�b�ܽb�/��X��1\<�z��2>�V���N�<�=�W�=oFI="a���=�qv<�l=r�p��ʙ<�&���;�q< >�������=�UJ>J��TI�=o�>�)g=�B����;}���;�<|G"<��>������!?q��>o������=����{�����C�(*�=�aF��l>lN��;ϼ��X?o��>�Ó;��b�z1=�i>v��=��\>LV��5�>v�������Uc�w����OY��!׽l�Em�cĔ=��.�!==׻"�(�Pc�=�[�<�>07�N͔�4I9����S�p*=���>��=̺>�??��=��֠�>Q����c�p�Ŀ�Q�=�m��?�<��S<y�?���|>Gv�@��=H��j��gdj?��=��+>���=8ü|���D^�<Ԍ��R�>�z~>��-�d`�=�# >��D��
?t9�>�oV==��<&�>A��<�����>�nB=6��>Mνq�@�(��>��>���>����C>�w#?s7^��Cξ	�0<tX��BK�η������3������=,�K>�j�WPƽ :潫���S��Z��>��>�=�V��(8��!��8��=ۋ<;V��=��	>�3=>(�<�
ۿݳ>�Ƚ<8?�#��I�= -?�d�>�b�>��iZ>��L?����禾�����,h�-ĽU�_=e?�=݆��r�=>�����	>7��<�wl�".��<B�u�v$M��9����>E�G=hJ�<�	V?E'ƿ�;>�,\<Ӹ"��c=bc��C�ۘ����.�]���.>d��7[8�����b��=8��<"X��:>L?���u|>���;G�%�?=fdf�[Ѻ��<����ƕ�h3��l���o��$�	>e��x�=�9�P�=���ͻ$��{�+��=;�;�KJ=ɪ��RB8�K��<����S���|=����<��=}�$���������=��	��������-��<f��䝡���^��<=~��*�Ǿ��=0D�,&��ӱ1>��ӻ����<������:W߄=I�=ۨ����w�> e�C��f�G��A&>�VнL�3�0�n��F���k>꩎=�N��^�u6�=α&>g =l���JN>����-!>�Ȫ=��a��yT�҂b=���=(�p=؊?&/Ŀ
5�P<s��V����=�_�Nr�]�>�|@���=`�d=�6j����໲���=�]���G<�HF@��KG=�����z��K�>.�=I�:�ڽN�8��|���21�O>HzL=��o��.=��=��ս���&�>NY�=n�f={��=|�7��E�-��l�>��>�{!���'�=��꽮�s�����佒>�=H���7K��Ć?풻��N ����ٍ���=�Ͷ�V!��R�^!�hg��[u�=��}�?k��Ļ��n�=�N�<Xc���=M����⁼���=�y���~����`UX��j
��y���\�=$Cw>�r	>;�����]��=�Y�Vv���w���O�� 5>�����?��=��x�<�/kS��)[=��Q>��r>\�(��>�c��tE�?�Z`���G{>�������=A�8���ӽ[f��a��2�U��?2?��?=�󷼽��l*.�/ܺ�>�-� �>.�þ<�5) �RU��G��7ƾ�Jɾ�C����>6J�=cۑ��vV?uh9�]�=+��9�a-��,��<�^�=�~����ړ�=$�������3?���t�W4P�!��Є>���<!�f�S(?�Lt<�k9�3�ھG/��9γ����:�=B!����a��Ө<�	+���j��2��D�Ѿ������=�I]>]оǤU?.�e�Gw<����|�]��?�=?<���������>�z�����9`f?'�w��w��89��Y<�=$�>PҊ�6�1<`��>(7�>bhξ����p忒� ��kR���B>n҃��Ѕ�]BC���Q�tѾT��ᠾF�4���V=�_>1&���T?��J�m;p�0}H����=�BD>K+�>)&���'����`{�=S���/u����?�\-�@���`��J>x<�a��=��=��k��-�=c;����޶�-���(���A%���ܽ����(>9C�P�<�zҽ&���x�=D���c=�+�=h#�<XiV����=؈�<"J>�Vz��Ȧ��k\=���j=�ݭ�ފ�����7��i�>J���F\�=n�0� d=�����>d����l�z.�=��=�����<7�����>�5�:t��p�i;#l���U����Uw����5�S�>�2ƾ��?^���S�j���9�Ѿ@�ؽ˃�>�0�<dL>�����VuL�a���*���)��JXG��[�� � =J����|�=	��5W��K���J�?���L*~�8c���+�=ӌ�