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
qBX   1551892094320qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1551892095952qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1551892094416qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1551892094992q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1551892094512q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1551892094608q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1551892094320qX   1551892094416qX   1551892094512qX   1551892094608qX   1551892094992qX   1551892095952qe.(       q+�>��>S"?��X=��=�p�> ������Ҽ����0˽�Ľ��>g5F?�n7>���>l����f�ѡF��i���>!�U���G��؟�S�?@˽��?�>�>j '=�`�9N?�t�=+ڞ>�2��΀��@	���<r)G��[O>�Q��@      :��� l-��s��9��}��}�1�lzZ�b���r�S�eN��)�r�v�ɽ��Ľ��E��Lɽt�������f���(��Yj������d7���!�9!��@�=������͎ ��C�%/��D�"��}'�;��=~���Ф��������G3���#<($���8=��Ž�42= �ǻ�m�T�=������=�9�=K��=��=��N�<��<��ｱ�r�1d�<NNO�f�M��=Щ���^�=R�=��3��uD� d�#NW�V���~ӽ:�[�j)C�P;��g�=�;�D#�����,нy[< ޽��H��p�>�8��I�J��=���?V����C=�g���T���>��#E�?�l��3��칰��1����� ľ���>л��3�='���>�!k�Mz��p�������:�=H3��\���^��]L��w�Z!���̨�	�ཹS,�����1����(��!�f��=�;?x?=��)�¾�B�������l��?�����=��<��L�=l���}s�DE@>��B�#뱼_��;&�7�|E�G��=b͎=����qP�� y?l�A��(�+\
�,D��>��=L�Q=�~��K���-]�أ�=�(�'>�*��< _�0����"?�⽁�D����0�%���a���Q?����/�E�I�$7J=�4��¿4Ǥ���Q�|�>�A��$e=����e�=@<�<�
=�kz�vb?h�ǽ ��7���LA>��O=�8=������>�b�����=����*�;� �=��;4X=��=Hɩ=ݶ���<!:�&=:�F���.��w�<�Dw��߶����(��rz��8k� �2�q���l�= *�;��u�(:𽭽YX�=�8��;�;Brν��ؽ+@I�as޽�=�5G�AK��H/�����E���u7��)>�n��U?]>V�ٽO�%?a�>KX�j�����^��o���/��?<z=�a>7	ҽȈ�=����ۏ��،���.�����A<�˕�����<��)=�CJ��μ�;>��=�@�>��<���=ʇ�=��ǽз�v.w�� о�ͣ<�w��[���5�;�� �2=��0��/_�L�۽:o�\?I����5 =z�/|$��=6�����v�=ˎf�3i@��f�=D��Zp?�pԾ��|��<�ĭ=�4:=&Fo�)Ii�wُ?>3�Bl|��݈�][�g�ᾌL����A>x�L?�,�E���G�׸t>�Ϳ�����=��x?�,�fP���]g����܌A>�j��._�?.��M��Ȕ�9�ǿ(A����1<���>��>��Ӿ��"����;@���ӿ�w>пB��W���:x�z�߿N,Y��Ό�E#�=�o$����;�v��8����=nO=OZ��J�=����)��gn�t�>��M����x�a<f����<�S���f
�f�<�w=����%�� ��^?�o�>0���Y�o�<3u��(����=�'��
e�=y�l�
���Ё��&����޽�$ɽ"�=�I��|�¿�7��q��В���G�x?k��4~O����`2���d��M�����>G��=H�?�q
<$W�<<����̖<M����d>�c��-O^>���=0�ؽ]�����:?�-?�����o=^y��~O��ᄽ���z�=�T?$��<K��b��Y�??�I?�pY>���P=Tz=P�>A-����=�=�������3?fF�=g����L�,5���L�SQ6���]?�o`��>.��xL��ꭽ`����U�ϩf�W&ﾾ�޿��s��)�+p��4����<��;���=V�п�� �OQ)��=@���$��ɗc��p���.�؍�;�6:��R>��E��c�n��s�=Hk�=͍���=� j���)=��+�<��սJ~�<�\;���=�T\�ǡX�h���]V��[�̺p=ؐ)=p$��(=�{�<?��=D�\��S$������R�<-）O =���8=>��<:rK=���;����Rܺ��Y�� �1��0|�=��0=(5$��w�=,%��=��q�>�����Ͻp%��>�>�=.`���(>���´�=�x��d��T�<8�n�5��=W�U��=��q�wc�>攡=0U�=0ַ�]��=�d�<�m=�*g��Q��3����'��<�����,>�̴��>ƿ��4��22=����|V�?��2=䫽ǹ��ꗅ=��.�r�A>�{E?`̇�����>Lj򽄘ͽI��>�H�>e���7!���=
��^�1>������� �%�ӽ��&�%#��	ֽ;>8���{>uZ۾/k�&��;��=BF���>Ϟҿ���b���7�}iE>�n�=͖�����pb�!���F�l�>Ζ����J#��7�;�[���5���_;��&�𗴿��.��{=�	��\$�������Vܽz�=m��+�徂/�=�*�ޜ־�V���RS���ͽ�2��wf��r�"��>��kD��$%?|�߽CfK��ڮ>$�<�M����?(�����!�<���;?֌>���=B�@>�=_�����+�>�w=�F�=�῾�S���k>0��>*t�=1>�Md���g>0�����?W`��1ݡ=I����l�V�����>�� >������a� �?Tu?@J��x�={*�>�k�i��T��q�����T�g��*D?�7�
l/� 6��ӵ�ž3�a����ϾU��!�>)ɇ�\ս�~�M��i��h��<m��=9�->�mC>����o��3I>/�>�������M�y�Exj��W����>O���N��-?j��7 ���W=U��>�w����D>�'�[��h���6<ͽ��2?TU=�����9:�#�3�'��=;��to>�7>"�>f�W� l�;�(|���]��d!���K�s_�*��>��6�o���8�Q
����4>�*ݾH5J��e?:������E�� �=�Ҿ�х��n=�rC>2�1��[�ĉҾA(�?�����A��Z<��&	�����<��\P��}��PI���6��y(?��7=.��=J� �m!T�z�T�J��=�`=�b_?��>�&`�����H�>���8��<j��<.(x?����A�M>DEi�l4�>&�>�����Q >RX׾r�->��L�� ���D�>T�ǽ�ۘ�� 	�K��=Q�d��<>�ା;>N>q�H�j��>0w>�T}�����.l�&��=�f>���>���>��> ��c	�=+&�<O>󴀾����6k������I<��A>x�>�NP�������~1�(H��,½	���:�	.ԾR���o<��2Y�X�ǽd������z?���o��V;P�����Y������o����\S�^�O=�Y>��
>^@ҽn���� �R��ރ���S=9�������A;�͘�;���<�>��g�Ț���Ȍ<H���+Z'>�g��j
�pb��\��b=�R��!>v^���x��� >��ｽ*����;jG=�ҟ��2��6�0e����{3��$=TZ�=�;< 6�k�����<�VJ��V�q����g!������t�=>�tɽR ����w=��@�H;'�Ž�̆���R=�D���S�@�C�ӵl��8I�b�1�m�H��<3���0<�?��<w�@������=U|�ęN���<�j��>X��Ǟ� �5:��=�М�=�^��=�3ѽ��`=�r�^ƽ+(�<פ��1$�Hm&=���B�"�8�վ�.J=/W ���m���c�>>���>9#>��=�b=��w�=�����q��7�=Ya�=�'F?���>�d���<佀��@滶�c>��=Sr
��޾&����t<>`]r�T{���X�+:����:��O,��r���)+>r�ջo
l��S?̂ڽ�g���?��=>>W�._G>�3����%��?ߐF��پ���>D2?eH�>�܁>z:�=�(��t��N�����>f윾(sѼ2І>�W�0+c=��+�"���B�;�h��?�Ǿ�)S�*���� پ��ѾB\�?��+���=������ټ_-�=~h�=L�ϼ��Ž֫�=���C��h+Ƚ����ʑ�#����h��p��=�Ž�v;�V'=�&��G�=J��`�O<��>���Q3=�T�=�,���?\=i��8i��P�P_��k����;0��弩���������==H.�<�V&��7c���I��0>R��>Y^`�E��=!�j��	^?f����A�/?����2������W�ve=M����O�E2�����/5�����=A<�<Y�ܾЎ�<���H��'G
�n���[�H�D���w�i�">��R>Vԇ>j��>�79>�����I�p�|�,��=o{���F<�̇����=`�=#�Y�+=]P��MM��s��v^!��-6�b���NFK<�����ǽ�P�=��=�/� 1A=T�=���<�ӻD+��l��b�n��<��=wl�=7w�=���U7�=U�h=�u��+�=��$���
?���=Դ��a�
���j?b�;O���$�H6ȿ$ �����N? ��#���?�c�� &�s���B���F�o>F0�*��=�۟��Ƚ-1�	S��4H|��si�j����Έ>�댿?����:�;�o=�#9��߿UMѾ!8�}S���o�<���=����ph� ���F\��5;��ʽO1;9�ؽM=L�o/�f��\���*��(�A=�d5��,-��ն�o |�Q������=*ҳ�(E�<����e��<<�=꽔=��.��Hн �����=�hʽه =�|��X}=�t=�о�)k���Q/��&<��<�#��~�nؽ+�a���὜�m�p�	=�{�p��iF��=�Ќ<�o��yӉ��H�0�S�VH�<�,�<� �<H�6��Hi�<�|7�~�	=x�"=��q��W��h���;��i� ���A	�=ҐH� �2���3�:�!=JM���==���=�=��߽�����3��y#=Yx'����� <q-|�٧d�,(��k�=�? �����q�c��=y�޼R��<�/P�θս^��ىC=���=�P�<� 8�$>ý��/���BY =NY��1��n>+����<DO�.��=]�=� ��������TO�3v>p#S�РC<���=��g����=�ᄾ��,�c���\���~I�������=�d��Ȳ��h�<��=8�	��,?</�۽y�*�x�%���=�4��\(q=���=�|����=���H/���X�_Q���߽�d�Qֳ���<�QO���$�2b�=dq��s�������W���T"A=(�u�B��<ެ>��f�ꀵ���<�%=��i����hUO�+*��)���I�����������E�p��=�o&��B�<����C�����t����k�ͦ���r�z�l�s4������B�=��̽�A���>"R���=��#�;��9=�[�;�F��M�=�6��#=�"�f=���^c�S �=���_�<�	�~E��z��=�3��k��gpR��z��s8=X�<&qν��9<3H�;�ߟ=���<=Kԓ=�k���l��*��(o����=������V�<�j���#=�/=�ğ>b����7L�q{�>���"��[r2?�ξfi����'���8�>�����@u>4B����=L9�ɭ�yt!>|�_��. >�B��0&�>2I�x/�>&��>�`;�H�����>�|�=�w>le�CK��i������L&�t�k=�!>�.�'�#����<���=����1�<ԯ4�]������MdU��6g��Nؽ����=J��=�[��;����s=\>� &5�&X<e����_Ƽ�N?�o���>���c���΀=��;���=�Í=R����,�8���=�	�I?=�x�wZ=��<����g&��؁���!��L	?V{��`��9BҼs^��/�$�7�P��AA?�؅�ݑ�R$�k�����*��[����=�N�������ʨ���=n	½����La=���ðI��=��ɗ���Ƚ�ަ��})��$��!��Ǎ�ti� w����P���p��>TV�>��Z��A��~R�Ʌs��� ���G��(��t½G�����[�W�W>>��o���G*<�w��I�?	Eտ%��>��'=󞤽�Y >t~B�N�)�C�>� ?-��>��]��Y��:���ZX�>�Z�>�ڂ��ˉ��Ӊ���Ŀ^T�w�->P}?(       w�V=��&?J�E�h�޾�J�~�������xb?��?��?�Ӿ�\I=?W<*zZ��$پ�Ƴ>��?��>u�.�Jl�>��>�ֽ�v��f?� ��>�ِ��X��_����?�ҙ���_>␞=8��=U�G���U�=��>�*������?       �X��(       �����2�=OS�>����X�>];	=}:=���k�v>�hv=i�o�e�X���0����>dul=�,u�oE�>�f>k�$?Xc���<��`%��,���Z?@����:R��9��i.%��]�>y�U�MnZ���]���m�}v^=�F*�i�]�xD��l�ż(       �� ?G�y=�
��N��H?�X��y ��8ʆ>�5>.��>l_�>�4'?K���ڿ��f�Mik���k��>�>���>���>i�]��h!��n�>�t�*�d���I��kz����>�_�|$�ˤ�=���>�Z��@r��D޿�V?�����=� �>