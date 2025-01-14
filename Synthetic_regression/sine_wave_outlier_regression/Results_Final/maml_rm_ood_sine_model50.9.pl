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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2084927052528qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2084927053776qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2084927057808qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2084927056272q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2084927053584q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2084927055888q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2084927052528qX   2084927053584qX   2084927053776qX   2084927055888qX   2084927056272qX   2084927057808qe.(       ����eX��C>ƼJ�"D�4����>0wӽ�5�2d�>�����?Cȷ��]羟�9?;�����@7ɽ(�۾f+?�k,��Dӽ�������d��"߾]�۽è����	���ӽ�'?E�?����C?¢�=(������8���z��|�*?(       pz��OG?@S��>BLʽ���><�o>��?�1�>0<?<H��>��>�N9?UK�<���U�	�ߧ�=��E=}�?�dU���=w>�=!w6<��=�[Ze�_8h;���s�?���=�R�=;�>�/=�jľ9U�> .?�~���[����?�8�(       X� �e��>�ei>%e��E�ӿ%�m;������>˽���+�YsC�:p߿6=���`���k/X�q�`�$��>\�;����) ���>m�?��Ŀp�[� ��/f��;O�k�?jC�>1J���#���K>e屿!�?�\�>�#��B�T>����|8�       �s]�(       �+>A�<1<�H��oz�<� {>�A�h&>#�a�0�B� ��qA��ҏ��I.<�uX?,/>��};��_��=
,�<�^�q�6�!����>r�>�z�=���� ��ݕ�>kb��c_��Ma���Q>?�>hј�]��>�t�$�o�~�y�>@       ~��L̽%C?4�h�QwG��ƅ� �p?�,;�K�>N��>�J���k�~a�>�P!?�;c��d��Ȍ,?V�̾���>�����[~=h��N?�? ? ����D�=^l��X�|<����GNy�����,^q?�����ǡ?|A�>��>I���v>�>?=P�j�侮��"�_=�e���Q1>��x�ci�mҼ�������>n�0�1}=&���Y7���y������x>Q�>n�+�o��1��d��?͑����=�r���F>Un�=^��=��	>�|t�@>�x�d?����>4�>?�]���>pQ�ݛ�6#�=��ξH��<���ڊ9�&�a��u�ܲ���}=4��=v�����M�g\ʾ�L>־>S��3����_%�6�z�����Y�=3Mf?�V���wӾ��}��K���p�X������8��������׿#�t<�?1Ƭ>x@���٧�����eo��e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ=���=����Bn��:ӽ}�W��6�Abm=���<�_Ž�K¼�a�=>��=�(�Y���={�ͽ*�<��`>����P�U�}���4��c9�Cf�Rn_��|(��A��j5T<-�Ͻ�<���@�@Ͻ��=z'޽�<�r�6N���>֘i�Խ�=|��e�w<!=�,���b�s���`��c=�	����@���ѿ򿆽h��ٟ��G{ �p��R�ؼºȽI̿��k������}?�)��m�,��ﺾ��o�Vu������2E��L�K�b��i&!>$\s��Z:?���>5g�Z/#���н
!�x~
=�M�U>�;�|���Q���z>c��� �	�W�:
�P/N��o��[���߻a&��!Ma�5ѽ�oz�V�g>_6E��yս1�S?^������!�3�ƣ=v��g�>�V�	�>��<��]?���;{�.�
����涼$�>/$]��"> ����(>f�P>I�{��ӻ�����>Q>ї�>��ƾ?>�0�+�Wtt��W����پ��X��R��^�@�1Ҡ�D���m�'S��w`��k�=��+���Ѿ�}O�K�����=�DA>�P�=��P��W>u�ɿ����9?t�6>
�"��3�d1��s�=0!��{\<��_>DC;���9�A=W�>�,=d�*�����"آ��>�_A���@���=`Zs��<��x6����;�s�=�k�Xr�=��G��}_�nF%�Ɠ�;6�E�e��<A��>IV�=�i>F^F>M* ?b6�>�Np��]l���Խh ?O��� >	�=�B��� =����0S�����v�W������(���8�Ͱ���3�����慾��!=np��CG��6��RL���=� �����ҽK׵��T��� ������9�뜛��Q/��!=�t�=�	��,���?��N�gA��C�����?�2�=m��H�F���&�Psx���C�>P�Z<� �lc	���>�`==S>x��<.�� .��H�����=�ښ���l�.��=X����6=NB�=ɩ>�X��Q���o=�)˽��\��+��,����>!�!>,�.j��  ��`�ý���L�N��a¦>N��?�ŵ��=�������>ɜ�>�=�������]��="�?6��>�Y�>	Yw�>7�>G]����>(?޾�����>�<�W�=�{���Ͻ��p> �N㱾�!�`v���̳�Ψ�>'�־ࠦ>m����z>���� >���>[�??�½Tę����=h��>I�?z��N��od�<1߯��u�F�'�U/�=i�v��~8�+�Q���=q�<���]=?��L! �GN���YI��)_��Ƚ�A��sH'>��>큹�
��>��>���>��*�4A��YW���%�XzC���?f٩�
����t<K��ߴܽ�(�=��*�W=�:���<�@�������,=^Oi��d=#���H�=$#���=jٹ=d��<^��W����̬��)i��wD�C�0�齡=�`�f�o�"�+��u�= ;=��A=��-����=E>�:m�Լ��b���Z�D�>�®?�/<=1S��|�=�ٹ<�>#�%����<c�����=<�-���܍��Y�~�$V>"ڔ�1��ܲX������ο��ھ�@<[�1>�4)>�x:!E?AT�>z/����>�O8?�-ɾ\W���:�������P?B+Ȼ1�>�~���JF���B����=�V�?=Ѳ>�ĝ������&->���>�;��;K>�L������6����=��3�,g;ٴ)�jG'�	�<�1?��pS>��N;��>]<&>�ݏ�PF�����}ܽ��=v�5>��+>�e>0� >�͒>�>�
��|ؽ�sǻ�8J=��=��jݽ�����=������>���<O]��F�6�=g����(q<B�ͽ��	��ܕ��X;���=	e:��#�=�๻��%��[�O�=��@�BRr=2ܽ"�ǽ0:ս�����V�+��=�;����<n<�=���Y�ӽg��ؗT=.V�P�<������W��R�<c4���!X���<u���u�p�I<�=��	��̵"�[A��`��.�(<�}� @�7(aѽ܀�+D��bz��|���d�f����@�=�3��+6���D��(�h�O=o9��a�p/W��� ���0�&��c�.��,���p6m�.=�#�p���C�L��������	O�3bʿ-C��Ft�S7ſN���پ���=�.(�f��S�ѿD�۽Kx�?�@ɿ����{j�EW=�4�Х<�0�?�#�A�澑C��uz��BN;?��?op���o��j.ʺ�%A� bq=M���e��{ t>�}~�F�Q>NTf;x���Q��=�,�=a��=���m>'Px=�<��wlx��� ��7�=��:Q��r���2}?���=�VA>��=6u>�G�=�lO�1�l�ߩ^�y�D�0k�>�My=>�>+x>3
�<r#>�CA=���f�ٽ�:��X�=9>�Ћ�� >p��ީ$� ��;�/�=ů!�������#?��}�[��Vм�=��V�V��=\7=s�l�/=#��f��(�<t�x=�s����ɨ�t!�<v0��۷��?�V��=x\�
���﬽����� p�o"����Yҽ����P-���
>�������@B��@���ݕ���'��(�=��=�~B�EU�۹��i���m� >N�&� \�;��]��8�� C�<am��� ��'	�̭0=轹T���q<�G������=�"v�r��(�ͽ '�<|�۽��=�h�t ��y{=��ݼE�<����Ł�O ��<�=�`D<��Π�=���=O�I�(���:g~�9.��Qw�<+?=�m�����f׾=��+=�2,��V�<�8�H@V=A��Ï���/�7��= �E�b�սO�ν�o�=o��;����=��=fw=��%�RY*;�T�=�p����;Dh��Î����d�]K<�0�п��m<�m��*��`�Ӿ�?r�XK����5�FQX�m|�Z�a��N�.��!���
+�i�#?�-{�!�t�?d:��р����P����W���~��>�>��w?rN�=5`�>�=n>��U��#z?ܡ[��?Y=>[�=@��>���?JS1=�z���>PCV=���>U2
��#ٽ��o�$��8�ż'�ǾP�e��X
�E�Ǿ@��>��`���p<R���C>I���'�=6; �->�z;���;@��>2>>E�<܁>v �>��Z�)(Y���޾M>o��0<?���R����Ū»<�V=O)=/���zܺ�\>��	&=�O��x�=�X>�S%=��|����Q���i����<��<���W�uLd���:�u�<�j���S����
��-���?*���ؽ`h�� e	����=��ӽ��������[�CW���ʳ���%<iP����>̋����i�%=#���h�ҽ���ݟ���Y=7���'�����=�!-��EO=��:=������������B�=��ݽb����*�=�`�<<�����=��Y=g����۽i#�<\Ђ��_�<zgb��������Y�W����R�
��r�=�02��2 �A����na��l�<����L���I�U��d�G8�ND#��Nq��K[�T�>ʚ�d�t�_���|m �Օܾ�*��T���?��tGp��iB�4BL�����Z�Ծ�*:�&������ᑿg�ռ���>@�>Ų3�n������
v�<�=@i�у��s��41H�C�1��������d;b�0Zq��妿�ʿ��&e�ic��|�u�u�PS�X���q��#�k��z���?>1P�,`��0��'���h�/k�=�>;�-��v�������5�I?�$'?I��`�Lt���ž+�	����w#~>Md�=1���x=���=���3Ѽ�!K�1YX��щ���<X2X���=ƾ#�n�D�~?�=��5�QX<2���s��=2���a��.��= :�<"�ҽ�L���Ws>��9�X}�>�Lm>�?�>U��>��<�*��c�=:?�U����= �c<r�=�pl>/'���δ=D᥽O���{=S�6�0o^=d�=��	=%���G�н3!��;�������=x_=ӈ=��z=���=��X��=������je�=����ν�"�x�$�М/�}�=��m��(��u���#�=��<��8NB���S��ig�^!$<�j=�=0��=yf=K��:I=�==U"	�������佷�B�g�	>#�����;���=�	���3�9諽˿j��V�^�����<m����=��1�D���=�Y��3臽c�>_���X���/���ͼ#E�[������V�)<$��>�,`�4��B�>Ij�>yN<4�>�s�>������yď>�n>�&�1����n>��b���0>ڷ^�=Z>�BE���<]ٿ���-��>�s�=Eh�>"_𽒆2:�@�$� ?�����f=����0���͢5>�F'�^��<�r?�O½I5���A߾,��,���8��(!=�=Ϳ�G=%5�'�������o�;[{��k�8�ƴ���-�=��K��Cӽ*���(Խ��?�?H���J�<�c>�3��EN>dA��(&��4��h#��#?�$>BM�>=�>Yν�?��Z[�=3�	��C�>0�0?u���b���U;v>:t�>��>��>��L�,��W��>p�>;��=�`A>���=M"ƽ�A{>߮�>��>	�-�����g�>��h���L>q�=�er=��=9�=��P=؎:>�����+[>o���zR���4>�`g���}>�$�>�C�<Y�=��Ƽ��N������H3�po�&��=�2��Lr����_���3�Գ0�r��J��v�����B�d�����tk��;����E?�.������ ��f ��D1���>�k���7���ü�/��鿉�_??G�?��q��p�����1	�+����������U���b>����&�(B�� �<A��F��= ������0� =�:� �<�� �Z�㽢��=+\3�.+�=pֵ=YA�;|�=��F�h��#�ܽ��?=����c���"*�.̽�h��V'��b�%��<��)���=h5�s�=�������?#*�-s'��S��Α���L/�+���|<��`�=<����s�Һ�=qċ�'I���C��6�f�=b�p���뗡���M�W7��N��������_=҈R�$�=����p��.���h=Z�k�':P��)�lV�0��*�q�=<b�=&�?�Q�=nT��3�>�w��|��Yz�>���>�3>wv���OX>���>`�?��Kl��n�>R��<I��>T���4"'>&�;�ɢ�j�>�� >�]�>��>썥>�����*�G�ž;@��p��>����!	������>5s?�>K���<�6?�_<�J�=3��l��s���4?a�>�>�L���ϖ�<�Q�>��r��f����&>V�c>vh�>���F�w���
��S2��� 1�� �<Nz�<�(@>|B?��>��=�`L>�����е�"�1�qe��y>�P��k�c>����